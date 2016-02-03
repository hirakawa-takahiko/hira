#!/usr/bin/env perl
use Unicode::Japanese;
use strict;

###perl -nle 's/sjis/utf8mb4/; print;' sem_keyword_754.sql > sem_keyword_754u.sql

#my @DAMELIST = qw(申 能);
my @DAMELIST = qw(
 ン 選 申 能
 ァ А 院 魁 機 掘 后 察 宗 拭 繊 叩 邸 如 鼻 法 諭 蓮 僉 咫 奸 廖 戞 曄 檗 漾 瓠 磧 紂 隋 蕁 襦 蹇 錙 顱 鵝 纊 犾
 ー ゼ Ъ 閏 骸 擬 啓 梗 纂 充 深 措 端 甜 納 票 房 夕 麓 兌 喙 媼 彈 拏 杣 歇 濕 畆 禺 綣 膽 藜 觴 躰 鐚 饉 鷦 倞 劯
 ― ソ Ы 噂 浬 欺 圭 構 蚕 十 申 曾 箪 貼 能 表 暴 予 禄 兔 喀 媾 彌 拿 杤 歃 濬 畚 秉 綵 臀 藹 觸 軆 鐔 饅 鷭 偆 砡
 ‐ ゾ Ь 云 馨 犠 珪 江 讃 従 疹 曽 綻 転 脳 評 望 余 肋 兢 咯 嫋 彎 拆 枉 歉 濔 畩 秕 緇 臂 蘊 訃 躱 鐓 饐 鷯 偰 硎
 ／ タ Э 運 蛙 疑 型 洪 賛 戎 真 楚 耽 顛 膿 豹 某 与 録 竸 喊 嫂 弯 擔 杰 歐 濘 畤 秧 綽 膺 蘓 訖 躾 鐃 饋 鷽 偂 硤
 ＼ ダ Ю 雲 垣 祇 契 浩 酸 柔 神 狙 胆 点 農 廟 棒 誉 論 兩 喟 媽 彑 拈 枩 歙 濱 畧 秬 綫 臉 蘋 訐 軅 鐇 饑 鸚 傔 硺
 Ａ チ Я 荏 柿 義 形 港 餐 汁 秦 疏 蛋 伝 覗 描 冒 輿 倭 兪 啻 嫣 彖 拜 杼 歔 濮 畫 秡 總 臍 藾 訌 軈 鐐 饒 鸛
 ＋ ボ к 閲 顎 宮 鶏 砿 施 旬 須 捜 畜 怒 倍 府 本 養 几 嘴 學 悳 掉 桀 毬 炮 痣 窖 縵 艝 蛔 諚 轆 閔 驅 黠 垬 葈
 ポ л 榎 掛 弓 芸 鋼 旨 楯 酢 掃 竹 倒 培 怖 翻 慾 處 嘶 斈 忿 掟 桍 毫 烟 痞 窩 縹 艚 蛞 諫 轎 閖 驂 黥 埈 蒴
 マ м 厭 笠 急 迎 閤 枝 殉 図 挿 筑 党 媒 扶 凡 抑 凩 嘲 孺 怡 掵 栲 毳 烋 痾 竈 繃 艟 蛩 諳 轗 閘 驀 黨 埇 蕓
 × ミ н 円 樫 救 鯨 降 止 淳 厨 掻 蓄 冬 梅 敷 盆 欲 凭 嘸 宀 恠 捫 桎 毯 烝 痿 窰 縷 艤 蛬 諧 轜 閙 驃 黯 蕙
);

my $str = undef;
my $dame = undef;
while (<>) {
        s/DEFAULT CHARSET=.*;/DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;/ ;
        s/sjis_japanese_ci/utf8mb4_general_ci/;
#        $str = Unicode::Japanese->new($_, "sjis")->get;
        
        #foreach $dame (@DAMELIST) {
        #       $str =~ s/${dame}\\/${dame}/g;
        #}
        #print $str;
        print;
}
