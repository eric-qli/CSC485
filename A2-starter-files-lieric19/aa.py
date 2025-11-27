import nltk
nltk.download('omw-1.4')
nltk.download('wordnet')
nltk.download('punkt_tab')
nltk.download('stopwords')

from collections import defaultdict
from typing import List, Dict
import torch
from torch import Tensor
from tqdm.auto import trange

# assumed available from your codebase:
# - run_bert(batch: List[List[str]]) -> tuple[Tensor, List[List[tuple[int,int]]]]
#   returns: top-layer embeddings [B, T, H] (on GPU) and offset_mapping per seq
# - class WSDToken with attributes: .word (or .text), .synsets (list[Synset|str])

def _token_text(tok: "WSDToken") -> str:
    # pick the attribute your WSDToken uses for surface text
    return getattr(tok, "word", getattr(tok, "text", getattr(tok, "wordform", "")))

def _sense_id(s) -> str:
    # works whether items in tok.synsets are Synset objects or strings
    return s if isinstance(s, str) else s.name()

def gather_sense_vectors(corpus: List[List["WSDToken"]],
                         bs: int = 32) -> Dict[str, Tensor]:
    sense_vecs: Dict[str, list[Tensor]] = defaultdict(list)

    # optional speed-up: shorter sentences first
    corpus = sorted(corpus, key=len)

    for batch_n in trange(0, len(corpus), bs, desc="gathering", leave=False):
        batch_sents = corpus[batch_n: batch_n + bs]

        # build a batch of pre-tokenized words (list of list of strings)
        batch_words: List[List[str]] = [[_token_text(t) for t in sent]
                                        for sent in batch_sents]

        # run BERT once for the whole batch
        # embeddings: [B, T_bert, H], offsets: list of list of (start,end)
        embeddings, offsets = run_bert(batch_words)  # embeddings likely on GPU
        B, T_bert, H = embeddings.shape

        # process each sentence in the batch
        for b_idx, (sent, offs) in enumerate(zip(batch_sents, offsets)):
            # Average subword vectors back to **original word** vectors.
            # We treat a new original word whenever offset[0] == 0 (and not [0,0]).
            word_vecs: list[Tensor] = []
            current_pieces: list[Tensor] = []

            for t_idx, (a, c) in enumerate(offs):
                if a == 0 and c == 0:
                    # special/padding tokens → skip
                    continue

                sub_vec = embeddings[b_idx, t_idx]  # [H]

                if a == 0:
                    # start of a new word: flush previous
                    if current_pieces:
                        word_vecs.append(torch.stack(current_pieces, dim=0).mean(0))
                        current_pieces = []
                    current_pieces.append(sub_vec)
                else:
                    # continuation piece of the current word
                    current_pieces.append(sub_vec)

            # flush last word in sentence (if any pieces collected)
            if current_pieces:
                word_vecs.append(torch.stack(current_pieces, dim=0).mean(0))

            # Now we should have one vector per **original token**;
            # if misaligned, use the minimum length to stay safe.
            n = min(len(word_vecs), len(sent))
            for i in range(n):
                tok = sent[i]
                if not getattr(tok, "synsets", None):
                    continue
                tok_vec = word_vecs[i]  # [H]
                # store for every synset of this token
                for syn in tok.synsets:
                    sense_vecs[_sense_id(syn)].append(tok_vec.detach().cpu())

    # average all collected vectors → one vector per sense
    out: Dict[str, Tensor] = {}
    for sid, vec_list in sense_vecs.items():
        out[sid] = torch.stack(vec_list, dim=0).mean(0)  # [H]

    return out