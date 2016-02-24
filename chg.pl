#!/usr/bin/env perl
#
# SmartStyle社提示手順
#  mysqldump --default-charset=sjisでダンプ→SET NAMES cp932に書き換え→CREATE TABLEをutf8で
# に対応するため、 sjisでダンプされたファイルをSET NAMES cp932+DEFAULT CHARSET=utf8に変換する
#


while (<>) {
        s/SET NAMES sjis/SET NAMES cp932/ if /SET NAMES sjis/;
        if (/DEFAULT CHARSET=sjis/) {
                s/DEFAULT CHARSET=sjis/DEFAULT CHARSET=utf8/ if /DEFAULT CHARSET=sjis/;
                unless (/ROW_FORMAT/) {
                        s/CHARSET=utf8/CHARSET=utf8 ROW_FORMAT=DYNAMIC/;
                }
        }
        print;
}

