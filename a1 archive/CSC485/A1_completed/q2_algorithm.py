# Student name: Yinuo Zhao
# Student number: 1007672494
# UTORid: zhaoy239

'''
This code is provided solely for the personal and private use of students
taking the CSC485H/2501H course at the University of Toronto. Copying for
purposes other than this use is expressly prohibited. All forms of
distribution of this code, including but not limited to public repositories on
GitHub, GitLab, Bitbucket, or any other online platform, whether as given or
with any changes, are expressly prohibited.

Authors: Zixin Zhao, Jinman Zhao, Jingcheng Niu, Zhewei Sun

All of the files in this directory and all subdirectories are:
Copyright (c) 2024 University of Toronto
'''

import typing as T
from math import inf

import torch
from torch.nn.functional import pad
from torch import Tensor
import einops


def is_projective(heads: T.Iterable[int]) -> bool:
    """
    Determines whether the dependency tree for a sentence is projective.

    Args:
        heads: The indices of the heads of the words in sentence. Since ROOT
          has no head, it is not expected to be part of the input, but the
          index values in heads are such that ROOT is assumed in the
          starting (zeroth) position. See the examples below.

    Returns:
        True if and only if the tree represented by the input is
          projective.

    Examples:
        The projective tree from the assignment handout:
        >>> is_projective([2, 5, 4, 2, 0, 7, 5, 7])
        True

        The non-projective tree from the assignment handout:
        >>> is_projective([2, 0, 2, 2, 6, 3, 6])
        False
    """

    # *** ENTER YOUR CODE BELOW *** #
    n = len(heads)  # number of words in the sentence
    
    # For each word j, check the head i = heads[j - 1]
    for j in range(1, n + 1):
        i = heads[j - 1]
        if i == 0:
            continue  # Skip the root 
        
        for k in range(min(i, j) + 1, max(i, j)):
            # k's head should be between i and j
            if not (min(i, j) <= heads[k - 1] <= max(i, j)):
                return False
    
    return True
    


def is_single_root(heads: Tensor, lengths: Tensor) -> Tensor:
    """
    Determines whether the selected arcs for a sentence constitute a tree with
    a single root word.

    Remember that index 0 indicates the ROOT node. A tree with "a single root
    word" has exactly one outgoing edge from ROOT.

    If you like, you may add helper functions to this file for this function.

    This file already imports the function `pad` for you. You may find that
    function handy. Here's the documentation of the function:
    https://pytorch.org/docs/stable/generated/torch.nn.functional.pad.html

    Args:
        heads (Tensor): a Tensor of dimensions (batch_sz, sent_len) and dtype
            int where the entry at index (b, i) indicates the index of the
            predicted head for vertex i for input b in the batch

        lengths (Tensor): a Tensor of dimensions (batch_sz,) and dtype int
            where each element indicates the number of words (this doesn't
            include ROOT) in the corresponding sentence.

    Returns:
        A Tensor of dtype bool and dimensions (batch_sz,) where the value
        for each element is True if and only if the corresponding arcs
        constitute a single-root-word tree as defined above

    Examples:
        Valid trees from the assignment handout:
        >>> is_single_root(torch.tensor([[2, 5, 4, 2, 0, 7, 5, 7],\
                                              [2, 0, 2, 2, 6, 3, 6, 0]]),\
                                torch.tensor([8, 7]))
        tensor([True, True])

        Invalid trees (the first has a cycle; the second has multiple roots):
        >>> is_single_root(torch.tensor([[2, 5, 4, 2, 0, 8, 6, 7],\
                                              [2, 0, 2, 2, 6, 3, 6, 0]]),\
                                torch.tensor([8, 8]))
        tensor([False, False])
    """
    # *** ENTER YOUR CODE BELOW *** #
    # Create a mask to only consider valid sentence lengths
    device = heads.device
    batch_size, sent_len = heads.size()
    mask = torch.arange(sent_len, device=device).expand(batch_size, sent_len) < lengths.unsqueeze(1)
    
    # Only consider the valid parts of the heads using the mask
    valid_heads = heads.masked_fill(~mask, -1)
    
    # Count how many heads point to the root (index 0) in each sentence
    root_counts = torch.sum(valid_heads == 0, dim=1)
    
    # A valid tree should have exactly one word pointing to the root
    is_single_root = root_counts == 1
    
    return is_single_root

def chu_liu_edmonds(scores: torch.Tensor, length: int) -> torch.Tensor:
    """
    Chu-Liu/Edmonds algorithm to find the maximum spanning tree for a directed graph.

    Args:
        scores (Tensor): A square tensor of shape (n, n) containing the arc scores.
        length (int): The number of valid words in the sentence.

    Returns:
        A tensor of shape (n,) where each index contains the head for the corresponding word.
    """
    n = length + 1  # Add 1 to account for the ROOT node at index 0
    heads = torch.zeros(n, dtype=torch.long)  # To store the head of each node

    # Step 1: For each node (except ROOT), select the incoming edge with the highest score
    heads[1:] = scores[1:, :].argmax(dim=1)

    # Step 2: Detect cycles and resolve them by contracting nodes
    for i in range(1, n):
        visited = torch.zeros(n, dtype=torch.bool)
        cycle = []

        # Follow the heads to look for cycle
        current = i
        while current > 0 and not visited[current]:
            visited[current] = True
            cycle.append(current)
            current = heads[current]

        if current > 0:
            # cycle detected
            cycle_start = current
            cycle_nodes = []
            while True:
                cycle_node = cycle.pop()
                cycle_nodes.append(cycle_node)
                if cycle_node == cycle_start:
                    break

    return heads

def mst_single_root(arc_tensor: Tensor, lengths: Tensor) -> Tensor:
    """
    Finds the maximum spanning tree (more technically, arborescence) for the
    given sentences such that each tree has a single root word.

    Remember that index 0 indicates the ROOT node. A tree with "a single root
    word" has exactly one outgoing edge from ROOT.

    If you like, you may add helper functions to this file for this function.

    This file already imports the function `pad` for you. You may find that
    function handy. Here's the documentation of the function:
    https://pytorch.org/docs/stable/generated/torch.nn.functional.pad.html

    Args:
        arc_tensor (Tensor): a Tensor of dimensions (batch_sz, x, y) and dtype
            float where x=y and the entry at index (b, i, j) indicates the
            score for a candidate arc from vertex j to vertex i.

        lengths (Tensor): a Tensor of dimensions (batch_sz,) and dtype int
            where each element indicates the number of words (this doesn't
            include ROOT) in the corresponding sentence.

    Returns:
        A Tensor of dtype int and dimensions (batch_sz, x) where the value at
        index (b, i) indicates the head for vertex i according to the
        maximum spanning tree for the input graph.

    Examples:
        >>> mst_single_root(torch.tensor(\
            [[[0, 0, 0, 0],\
              [12, 0, 6, 5],\
              [4, 5, 0, 7],\
              [4, 7, 8, 0]],\
             [[0, 0, 0, 0],\
              [1.5, 0, 4, 0],\
              [2, 0.1, 0, 0],\
              [0, 0, 0, 0]],\
             [[0, 0, 0, 0],\
              [4, 0, 3, 1],\
              [6, 2, 0, 1],\
              [1, 1, 8, 0]]]),\
            torch.tensor([3, 2, 3]))
        tensor([[0, 0, 3, 1],
                [0, 2, 0, 0],
                [0, 2, 0, 2]])
    """
    # *** ENTER YOUR CODE BELOW *** #
    batch_size, _, _ = arc_tensor.shape
    result_heads = torch.zeros((batch_size, arc_tensor.size(1)), dtype=torch.long)
    result_heads = result_heads.to(arc_tensor.device)
    
    for i in range(batch_size):
        sentence_length = lengths[i].item()
        score_matrix = arc_tensor[i, :sentence_length+1, :sentence_length+1]  # Extract the relevant matrix
        result_heads[i, :sentence_length+1] = chu_liu_edmonds(score_matrix, sentence_length)
    
    return result_heads


if __name__ == '__main__':
    import doctest
    doctest.testmod()
