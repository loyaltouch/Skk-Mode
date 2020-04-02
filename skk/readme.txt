はじめに
========

これは「高速で効率的な日本語入力環境を提供するシステムSKK」のxyzzy移植版
です。GNU General Public License に従ったフリー・ソフトウェアとして配布
されます。

移植作業においてベースにしたのはSKK8.6で、そのシステムのうちskk.elファイ
ルのコアな部分だけを移植してあります。


インストール
============

辞書の入手
----------

このパッケージには変換辞書が含まれていませんので、まず辞書を入手してくだ
さい。次のサイトからダウンロードできます。

    http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1

入手した辞書はお好きなフォルダにコピーしておいてください。

ファイルの配置
--------------

配布しているアーカイブファイルはだいたい次のような構成になっています。

    + site-lisp
      + skk
        + readme.txt     - この文書
        + autoloads.l
        + skk.l          - skk本体
        + skk.lc
        + skk-gadget.l   - 変換実行用のモジュール
        + skk-gadget.lc
        + skk-sticky.l   - skkを考慮したsticky-shift
        + skk-sticky.lc
        + COPYING.txt
      + ni-autoload
        +  kiaswebsite
           + skk.l

アーカイブファイルを展開し、site-lispフォルダの下にあるskkフォルダとその
中のファイルをxyzzyのsite-lispフォルダにコピーしてください。

ni-autoloadフォルダは、NetInstallerの自動読み込み機能に関係するファイルが
入っています。この機能を使わない場合はこのフォルダと中のファイルは不要です。


はじめの設定
============

__下記のような設定を終えたらxyzzyを再起動してください。__

__なお現在の版ではuserパッケージではなくskkパッケージを使うようになって
います。__以前の版からアップグレードされる場合はカレントパッケージの状態に
注意して設定を修正してください。~/.skkファイルは先頭に(in-package "skk")
と書き足すと多くの場合OKでしょう。


基本設定
--------

次のように ~/.xyzzy ファイルに記述します。

    (require "skk/autoloads")
    (setq skk:*skk-large-jisyo* "C:/path/to/SKK-JISYO.L")
    (global-set-key '(#\C-x #\C-j) 'skk:skk-mode)
    (global-set-key '(#\C-x #\j) 'skk:skk-auto-fill-mode)

ここでskk:*skk-large-jisyo*には変換辞書へのパスを設定します。先にダウンロー
ドしておいた辞書ファイルをコピーしたフォルダを適切に指定してください。

NetInstallerのni-autoloadを使う場合は(require "skk/autoloads")の部分は不
要です。(ni-autoload)の後に設定を記述するようにしてください。

辞書サーバの設定
----------------

辞書サーバを使いたいときはskk:*skk-server-host*にサーバが動いているホス
ト名もしくはIPアドレスを指定します。次のような設定を追加してください。
アクセス先のポート番号はskk:*skk-portnum*で指定できます。

    (setq skk:*skk-server-host* "192.168.0.88")
    (setq skk:*skk-portnum* "2178")

他のSKKシステムと個人辞書について
---------------------------------

SKKを使いますとその利用に応じて個人辞書を読み書きすることになります。

個人辞書は無ければ自動で作成されますが、デフォルトの状態では~/.skk-jisyo
というファイルです。またその最後の更新の直前の内容は~/.skk-jisyo.BAKとい
うファイルにバックアップされるようになっています。

もし、たとえばMeadowなどでSKKを利用していて、同じ個人辞書を同時に使って
しまったような時には辞書が壊れてしまうことも考えられます。そのような場合
には是非とも個人辞書を分けて設定するようにしてください。

個人辞書ファイルとそのバックアップファイルは skk:*skk-jisyo*、
skk:*skk-backup-jisyo*という変数でそれぞれ指定できます。なお、
skk:*skk-jisyo-code*で辞書保存時の文字コードを指定することができます。

    (setq skk:*skk-jisyo* "~/.skk-jisyo-xyzzy")
    (setq skk:*skk-backup-jisyo* "~/.skk-jisyo-xyzzy.BAK")
    (setq skk:*jisyo-code* *encoding-euc-jp*)


基本的な使い方
==============

SKKを起動するにはC-x C-j、もしくはC-x jとタイプします。

SKKを終了するにはC-x C-j、もしくはC-x jとタイプします。

実際の変換操作についてはEmacs版のSKKの操作に準じますので、それらの説明を
参照してください。次のアドレスからSKKユーザマニュアルなどを見ることがで
きます。

    http://openlab.jp/skk/index-j.html


Rev.139からRev.236への変更点
============================

以下はおもにSANO Masatoshiさんの作業によるものです。ありがとうございますm(_ _)m

*   (defpackage "skk")をしてその中に入れるようにした。
*   annotation付きの辞書へ対応した。
*   辞書に入っているelispのコードを変換実行できるようにした。


;; End.
