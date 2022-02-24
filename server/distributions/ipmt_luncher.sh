#!/bin/bash

poisson_seed="20"
poisson_lambda="1"
poisson_numvalue="1012"
zipf_seed="30"
zipf_alpha="1.7"
zipf_nvalue="100000"
zipf_numvalue="1012"

gcc poisson-function.c -o poisson -lm 
./poisson $poisson_seed $poisson_lambda $poisson_numvalue

gcc zipf-function.c -o zipf -lm 
./zipf $zipf_seed $zipf_alpha $zipf_nvalue $zipf_numvalue

