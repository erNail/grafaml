#!/bin/bash
pip install -r requirements.txt
yarn global add semantic-release@21.0.5
brew install helmfile
brew install norwoodj/tap/helm-docs
brew install kube-linter
helm plugin install https://github.com/helm-unittest/helm-unittest.git
helm plugin install https://github.com/databus23/helm-diff
echo "export PATH=$PATH:$(yarn global bin)" >>~/.bashrc
