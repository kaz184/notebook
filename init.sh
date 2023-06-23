#!/bin/bash -l

mamba run -n notebook jupyter lab --ContentsManager.allow_hidden=True --ip=0.0.0.0 &

wait < <(jobs -p)