#!/usr/bin/env ruby

require 'mysql2'
require 'kconv'

def getTablesAff()
        arr = Array.new
        client = Mysql2::Client.new(:host => 'car-dbm2bk', :username => 'read', :password => 'EiV3X8q1', :database=>'aff')
        query = %q{show tables}
        results = client.query(query)
        results.each do |row|
                row.each do |key, value|
                        arr.push(value)
                end
        end
        results = nil
        return arr
end

def getVarcharColumnsByTbl(tblname)
        arr = Array.new;
        client = Mysql2::Client.new(:host => 'car-dbm2bk', :username => 'read', :password => 'EiV3X8q1', :database=>'aff')
        query = "SHOW FULL COLUMNS FROM #{tblname}" 
        results = client.query(query)
        results.each do |x|
                if x["Type"] =~ /varchar/i
                        arr.push(x["Field"])
                end
        end
        result = nil
        return arr
end

def Select(sql)
        arr = Array.new;
        client = Mysql2::Client.new(:host => 'car-dbm2bk', :username => 'read', :password => 'EiV3X8q1', :database=>'aff')
        results = client.query(sql)
        results.each do |k,v|
                arr.push(k)
        end
        return arr
end

tablenames = getTablesAff()
tablenames.each do |t|
#       print "Table=#{t}\n" 
        cols = getVarcharColumnsByTbl(t)
        sql = "SELECT " 
        cols.each do |c|
                c = "`" + c + "`" 
                sql = sql + c + "," 
        end
        if sql =~ /SELECT [\w`]+/
                sql = sql + " FROM #{t} LIMIT 150" 
                sql = sql.sub(/, FROM/, " FROM")
        end
        if sql =~ /SELECT .*FROM/
                Select(sql).each do |x|
                        x.each do |key, varcharstr|
                                if varcharstr == nil
                                        next
                                end
                                if Kconv.guess(varcharstr).to_s !~ /ascii/i
                                        print "#{t}->  #{varcharstr} : " 
                                        print Kconv.guess(varcharstr)
                                        print "\n" 
                                end
                        end
                end
        end
end
