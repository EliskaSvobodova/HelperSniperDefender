## Task
The goal: conquest the largest connected component. The how: write a program that controls 8 agents in the grid. The challenge: there are 3 other players doing the same.

## Inspiration and 
The famous quote: Divide and conquer! 

## Desription
There are 3 roles, each implementing a different strategy:
* helper - helps the others to lose by finding their largest components and breaking it
* sniper - doesn't think much, just picks a direction and goes there straight and fast; with a little bit of luck, it will break many competitor's components on the way
* defender - takes care of my largest component by finding and strengthening the weakest parts

## Challenges we ran into
The participants are working on this challenge simultaneously - still developing new strategies to which other developers have to react

## Accomplishments that we're proud of
It works! 

## What we learned
Fast implementation of ideas
