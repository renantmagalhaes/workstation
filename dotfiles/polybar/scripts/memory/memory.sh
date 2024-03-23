#!/bin/bash

free --mebi | sed -n '2{p;q}' | awk '{printf (" %2.2f/%2.2f GB\n", ( $3 / 1024), ($2 / 1024))}'