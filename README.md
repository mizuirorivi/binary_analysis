# バイナリ解析ツール

## ディレクトリ構成

.
├── build 
│   ├── loader_demo
│   └── loader.o
├── configs
│   └── pwn_check.yml
├── doc
├── include
├── lib
│   └── loader.hpp
├── Makefile
├── README.md
├── src
│   └── loader.cc
└── tests
    ├── loader_demo
    └── loader_demo.cc

## 内包ツール

* heapcheck.so

  LD_PRELOADで読み込んだのち、実行ファイルを実行させることで、実行ファイルのヒープオーバーフローの脆弱性があるか、調べる

## 必要ライブラリ

* [yaml-cpp](https://github.com/jbeder/yaml-cpp)