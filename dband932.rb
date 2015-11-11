#!/usr/bin/env ruby
# encoding: utf-8			# このコメントの編集厳禁。必ず2行目に置くこと
# vim: ts=4 background=dark
# 
# 指定されたスキーマの全テーブル定義を調べて、VARCHAR, TEXTのカラムを探す
# そのカラムのデータにCP932機種依存文字が入っていたら代替文字に変換する
#
#  Usage: this.rb [--host=DBSERVER(default is localhost)] [--database=SCHEMA(default is aff)] [tablenames...]
#

require 'nkf'
require 'active_record'
require 'safe_attributes/base'
require 'optparse'

# CP932拡張文字の変換テーブル
# some chars are copied from http://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q1337585398 . thanks.
CP932HASHX = {
	"①" => "(1)",
	"②" => "(2)",
	"③" => "(3)",
	"④" => "(4)",
	"⑤" => "(5)",
	"⑥" => "(6)",
	"⑦" => "(7)",
	"⑧" => "(8)",
	"⑨" => "(9)",
	"⑩" => "(10)",
	"⑪" => "(11)",
	"⑫" => "(12)",
	"⑬" => "(13)",
	"⑭" => "(14)",
	"⑮" => "(15)",
	"⑯" => "(16)",
	"⑰" => "(17)",
	"⑱" => "(18)",
	"⑲" => "(19)",
	"⑳" => "(20)",
	"Ⅰ" => "I",
	"Ⅱ" => "II",
	"Ⅲ" => "III",
	"Ⅳ" => "IV",
	"Ⅴ" => "V",
	"Ⅵ" => "VI",
	"Ⅶ" => "VII",
	"Ⅷ" => "VIII",
	"Ⅸ" => "IX",
	"Ⅹ" => "X",
	"㍉" => "ミリ",
	"㌔" => "キロ",
	"㌢" => "センチ",
	"㍍" => "メートル",
	"㌘" => "グラム",
	"㌧" => "トン",
	"㌃" => "アール",
	"㌶" => "ヘクタール",
	"㍑" => "リットル",
	"㍗" => "ワット",
	"㌍" => "カロリー",
	"㌦" => "ドル",
	"㌣" => "セント",
	"㌫" => "パーセント",
	"㍊" => "ミリリットル",
	"㌻" => "ページ",
	"㎜" => "mm",
	"㎝" => "cm",
	"㎞" => "km",
	"㎎" => "mg",
	"㎏" => "kg",
	"㏄" => "cc",
	"㎡" => "平方m",
	"㍻" => "平成",
	"〝" => "``",
	"〟" => ",,",
	"№" => "No.",
	"㏍" => "K.K.",
	"℡" => "TEL",
	"㊤" => "(上)",
	"㊥" => "(中)",
	"㊦" => "(下)",
	"㊧" => "(左)",
	"㊨" => "(右)",
	"㈱" => "(株)",
	"㈲" => "(有)",
	"㈹" => "(代)",
	"㍾" => "明治",
	"㍽" => "大正",
	"㍼" => "昭和",
	"≒" => "?",
	"≡" => "?",
	"∫" => "?",
	"∮" => "?",
	"∑" => "Σ",
	"√" => "(ルート)",
	"⊥" => "?",
	"∠" => "?",
	"∟" => "?",
	"⊿" => "(デルタ)",
	"∵" => "(なぜならば)",
	"∩" => "?",
	"∪" => "?",
	"彅" => 'なぎ',
	"髙" => '高',
	"﨑" => '崎',	
	"黑" => '黒', 	
	"塚" => '塚', 	
	"纊" => 'わた',
	"兊" => '兌',
	"匇" => '匇',
	"喆" => '哲', 
	"甯" => '寧', 
	"嵓" => '嵒',
	"曺" => '曹',
	"裵" => '裴', 
	"蠇" => '蠣',
	"蘒" => '萩',
	"曻" => '昇',
	"增" => '増',
	"晴" => '晴',
	"朗" => '朗',
	"杦" => '杉',
	"桒" => '桑',
	"栁" => '柳',
	"橫" => '横',
	"淸" => '清',
	"濵" => '浜',
	"瀨" => '瀬',
	"精" => '精',
	"綠" => '緑',
	"緖" => '緒',
	"賴" => '頼',
	"﨣" => '赳',
	"軏" => '軌',
	"逸" => '逸',
	"鄕" => '郷', 
	"閒" => '間',
	"靑" => '青',
}

########################
#
# 文字列回り
#
########################

#
# 文字列を受け取り、CP932拡張文字を代替文字に変換した文字列を返す
# エンコードがCP932でない文字列はそのまま返す
#
def convertCp932Chars(str)
	buf = ''
	ret = ''

	# UTF8で書かれた上記変換テーブルと比較するため、引数の文字列をUTF8に変換する
	nkf_guess = NKF.guess(str) 
	if nkf_guess == Encoding::WINDOWS_31J
		buf = NKF.nkf("--ic=Shift_JIS --oc=UTF-8", str)
	else 
		return buf
	end

	# データ中に「'」があるとSQLが文法エラーになるため変換
	buf.gsub!(/'/, %q{"})

	# データの末尾に「\」があるとSQLが文法エラーになるため変換
	buf.gsub!(/\\\s*$/, '')

	# 1文字ずつ変換テーブルと照合してCP932拡張文字かどうかを判別する
	buf.split(//).each do |c|
		is_cp932_changed = false
		CP932HASHX.each do |cp932_key, cp932_val| 
			if c == cp932_key
				# 変換テーブルの代替文字を使う
				ret = ret + cp932_val 
				is_cp932_changed = true
				break
			end
		end
		unless is_cp932_changed
			# 変換対象でない文字はそのまま返す
			ret = ret + c
		end
	end

	# 処理の最初にUTF8に変換したのでSJISに戻してから返す
	return NKF.nkf("--ic=utf8 --oc=sjis", ret)
end

########################
#
# DB
#
########################

class CARDatabase
	def initialize(tbl, host, database, user='read', pwd='EiV3X8q1')
        ActiveRecord::Base.establish_connection(
            :database => database,
            :host     => host,
            :username => user,
            :password => pwd,
            :reconnect => false,
            :adapter  => 'mysql2',
        )
        @table = tbl

		@base = Class.new(ActiveRecord::Base) do |klass|
			include SafeAttributes::Base
			bad_attribute_names :attribute
			validates_presence_of :attribute
			self.table_name = tbl
		end
    end

    def getAllTables
        arr = Array.new
        ActiveRecord::Base.connection.tables.each do |tbl|
            arr.push(tbl)
        end
        return arr
    end

    def getPkeys
        arr = Array.new
        ActiveRecord::Base.connection.execute("DESC #{@table}").each do |row|
            if row[3] == 'PRI'
                arr.push(row[0])
            end
        end
        return arr
    end

	# varcharの他text, mediumtextも取得する（仕様変更）
    def getVarchars
        arr = Array.new
        ActiveRecord::Base.connection.execute("DESC #{@table}").each do |row|
            if row[1].index('varchar') != nil or row[1].index('mediumtext') != nil or row[1].index('text') != nil 
                arr.push(row[0])
            end
        end
        return arr
    end

	def getArrayBySql(sql)
		arr = Array.new
		ActiveRecord::Base.connection.execute(sql).each do |row|
			arr.push(row)
		end
		return arr
	end

	def getActiveRecordBase
		return @base
	end
end



#############
#
# Application
#
#############

class Cp932ConvApp
	def initialize(server='car-dbm2bk', db='aff', tblarr=nil)
		@db_server = server
		@database  = db
		if tblarr.class.to_s == 'Array'
			@tables = tblarr 
		else
			@tables = []
		end
	end

	def printSql()
		# DB接続
		tblobj = CARDatabase.new(nil, @db_server, @database)

		# 全テーブル名取得
		tables = tblobj.getAllTables

		tables.each do |tbl|
			next unless @tables.include?(tbl)  # コンストラクターでテーブル指定された場合はそのテーブルのみ処理する

			db = CARDatabase.new(tbl, @db_server, @database)

			puts "/*----------------------*/"
			puts "/*-- Table = #{tbl} --*/"
			puts "/*----------------------*/"
			STDERR.puts("Table = #{tbl} (#{Time.now}")

			# テーブルの主キーカラム名取得
			pk_arr = db.getPkeys

			# テーブルの主キー、VARCHARカラム名を全取得してカンマ区切りの文字列化
			varchar_cols = (pk_arr + db.getVarchars).join(",")

			# データ取得
			db_data = db.getActiveRecordBase
			db_data.select(varchar_cols).find_each do |db|
				updsql = UpdateSql.new(tbl)	# UPDATE文作成クラス

				db.attributes.each do |col_name, val|	# カラム名、値
					if pk_arr.include?(col_name)	
						updsql.addPkey(pk_arr, db)	# UPDATE文に主キー登録
						next	# 主キーカラムはCP932判定を行わない
					end

					next unless val.kind_of?(String)	# NULLデータの読み飛ばし
					
					# CP932拡張判定
					e = NKF.guess(val)  if val != nil
					if e == Encoding::Windows_31J
						# CP932拡張文字を代替文字に置換するためのSQLを作る
						#printf("/* [%s] => [%s] */\n", val,  convertCp932Chars(val)) #DEBUGPRINT
						val = convertCp932Chars(val)
						updsql.addVarchar(col_name, val)
					end
				end
			
				# UPDATE文出力
				if updsql.hasData?
					update_sql = updsql.get 
					if update_sql.length > 0
						puts update_sql
					end
				end
			end
		end  # end of tables.each 
		puts "/* >>>>>>>>>>>>>>>>>>>> */"
	
	end

end


#
# VARCHARカラムのUPDATE文作成
#
class UpdateSql
	def initialize(tbl)
		@tablename   = tbl
		@varchar_arr = Array.new
		@pkey_arr    = Array.new
	end

	def hasData?
		if @varchar_arr.length > 0 
			return true
		end
		return false
	end

	# VARCHARカラム名と値を得る
	def addVarchar(column, val)
		@varchar_arr.push(%Q<#{column} = '#{val}'>)
	end

	# 主キーのカラム名と値を得る
	def addPkey(pk_col, pk_data)
		attr = pk_data.attributes
		pk_col.each do |pk| 
			@pkey_arr.push( { pk => attr[pk] } )
		end
	end

	# UPDATE SQLを返す
	def get
		return '' if @varchar_arr.length <= 0
		sql = "UPDATE #{@tablename} SET "
		sql += @varchar_arr.collect{|v| v}.join(",")
		sql += " WHERE "
		@pkey_arr.each do |pk_hash|
			sql += pk_hash.collect{|k, v| %Q<#{k} = '#{v}'>}.join(" AND ")
		end
		sql += ';'
		return sql
	end
end




####################
#
# main
#
####################

params = ARGV.getopts('', 'host:', 'database:')

dbserver = params['host']     || 'localhost'
db       = params['database'] || 'aff'
tbls     = ARGV if ARGV.length > 0

c = Cp932ConvApp.new(dbserver, db, tbls)
c.printSql
puts "/* END */"
exit(0)

