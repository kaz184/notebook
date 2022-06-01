#!/bin/bash

jupyter lab --ContentsManager.allow_hidden=True &
julia -e 'using Pluto; Pluto.run(host="0.0.0.0")' &

wait < <(jobs -p)