#!/bin/bash
set -e

HIGHLIGHT='\033[0;37m' # White
NC='\033[0m'           # No Color
NOTICE='📣'

announce (){
  echo
  echo -e "${NOTICE} ${NOTICE} ${NOTICE}: ${HIGHLIGHT} $1 ${NC}"
  echo
}

export RAILS_ENV=test
for d in spec/*/; do
 if [[ $d != 'spec/factories/' ]];
 then 
  announce $d
  bundle exec rspec $d
 fi
done