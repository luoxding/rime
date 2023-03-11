#!/bin/bash

############################################################
# [0] 定义变量
############################################################
main=xqzm_main.dict.yaml
custom=xqzm_custom.dict.yaml
brief=xqzm_brevity.dict.yaml
gcm=zmgcm.yaml
merge=tmp/xqzm_merge.dict.yaml
sort_mg=tmp/xqzm_sort_custom.dict.yaml

new_mains=rime_user_dict/xqzm_main.dict.yaml
new_custom=rime_user_dict/xqzm_custom.dict.yaml

out_main=tmp/xqzm_main.dict1.yaml
new_main=tmp/xqzm_main.dict2.yaml
sort_main=tmp/xqzm_main.dict3.yaml
out_custom=tmp/xqzm_custom.dict1.yaml
code_custom=tmp/xqzm_custom.dict2.yaml
out_brief=tmp/xqzm_brevity.dict1.yaml

baidu=tmp/baidu_zm_`date +%Y%m%d`.yaml
baidu_txt=tmp/baidu_zhengma_`date +%Y-%m-%d_%H-%M-%S`.txt

############################################################
# [1] 删除头文件
############################################################
rm -rf tmp/*
#mkdir tmp
#使用if语句来判断目录是否存在，如果不存在就创建
if [ ! -d "tmp" ]; then mkdir -p "tmp"; fi
#sed -i '1,30d' filename.txt
sed '1,30d' $main > $out_main
sed '1,41d' $custom > $out_custom
sed '1,39d' $brief > $out_brief

#可以使用sed命令来删除文件中的空行，具体命令为：sed '/^$/d' filename.txt
#可以使用sed命令来删除文件中所有的空格，具体命令为：sed -i 's/ //g' filename.txt
############################################################
# [2] 删除用户词库注释词条、空行、空格
############################################################
sed -i '/^#/d' $out_custom && sed -i '/^$/d' $out_custom && sed -i 's/ //g' $out_custom
sed -i '/^#/d' $out_brief && sed -i '/^$/d' $out_brief && sed -i 's/ //g' $out_brief
sed -i '/^$/d' $out_main
# 添加日期标签版本
sed -i "/vers/a $(date '+%Y-%m-%d_%H-%M-%S')\tvers\t4" $out_main
############################################################
# [3] 为用户词库添加编码
############################################################

# 读取file2.yaml中的编码表
declare -A codes
while read -r word code _; do
  codes[$word]=$code
done < $gcm

# 对file1.yaml中的词组进行编码
while read -r word count; do
  if [[ ${#word} -eq 2 ]]; then
    # 2个汉字取各自的前1个字符
    #code="${codes[${word:0:1}]:0:1}${codes[${word:1:1}]:0:1}${codes[${word:0:1}]:1:1}${codes[${word:1:1}]:1:1}"
    code="${codes[${word:0:1}]:0:2}${codes[${word:1:1}]:0:2}"
  elif [[ ${#word} -eq 3 ]]; then
    # 3个汉字取各自的前1,2,1个字符
    code="${codes[${word:0:1}]:0:1}${codes[${word:1:1}]:0:2}${codes[${word:2:1}]:0:1}"
  elif [[ ${#word} -eq 4 ]]; then
    # 4个汉字取各自的前1个字符
    code="${codes[${word:0:1}]:0:1}${codes[${word:1:1}]:0:1}${codes[${word:2:1}]:0:1}${codes[${word:3:1}]:0:1}"
  else
    # 5个及以上的汉字取前4个汉字的第1个字符
    code="${codes[${word:0:1}]:0:1}${codes[${word:1:1}]:0:1}${codes[${word:2:1}]:0:1}${codes[${word:3:1}]:0:1}"
  fi

  echo -e "$word\t$code\t$count"
done < $out_custom > $code_custom

############################################################
# [4] 对输出的用户词库添加权重 6
############################################################
sed -i '/^$/!s/$/6/' $code_custom

############################################################
# [5] 合并文件并排序
############################################################
cat $out_main $code_custom $out_brief > $new_main
sort -t $'\t' -k2,2 -k3,3nr $new_main > $sort_main
#sort -t $'\t' -k2,2 -k3,3nr tmp/xqzm_brevity.dict1.yaml > tmp/userjm.yaml
############################################################
# [6] 取前两列以生成适用于百度输入法词库格式
############################################################
#cut -f1,2 $sort_main > $baidu
cut -f1,2 $sort_main > $baidu_txt

#iconv -f utf-8 -t gb18030 $baidu_txt > $baidu_txt-gb18030
# && iconv -f utf-8 -t gb2312 $baidu_txt > $baidu_txt-gb2312
#iconv -f utf-8 -t gb18030 $baidu_txt > ${baidu_txt%.txt}-gb18030.txt
sed -i 's/\t/ /g' $baidu_txt
awk -F ' ' '{temp=$1;$1=$2;$2=temp;print}' $baidu_txt > ${baidu_txt%.txt}-fcitx.txt
# 最终的fcitx码表文件
head -n 12 zhengma.txt | cat - tmp/*fcitx.txt > fcitx/nice_zhengma.txt
# 最终的rime新码表文件
# 合并用户词库
cat $out_brief $code_custom > $merge
# 排序用户词库
sort -t $'\t' -k2,2 -k3,3nr $merge > $sort_mg
# 添加头文件/用户词库
head -n 33 $custom | cat - $sort_mg > $new_custom
# 添加头文件/新的主词库
head -n 29 $main | cat - $sort_main > $new_mains
