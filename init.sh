#!/bin/bash -l

jupyter lab --ContentsManager.allow_hidden=True --ip=0.0.0.0 & 

wait < <(jobs -p)