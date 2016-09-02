#!/usr/bin/env python3

import optparse
from bs4 import BeautifulSoup
import re
import jieba
import pickle
import requests
import asyncio

if __name__ == '__main__':

    # 读取10000个关键词
    fs = open("./src/keywords.txt", "rb")
    keywords = fs.read().decode("utf-8").split(",")
    fs.close()

    # 找出特征
    def find_features(doc):
        words = set(doc)
        features = {}
        for word in keywords:
            features["contains %s" % word] = (word in words)
        return features

    # 读取预先做好的nltk分词器
    fs = open('./src/my_classifier.pickle', 'rb')
    classifier = pickle.load(fs)

    # 匹配中文字符
    regex = re.compile("[\u4e00-\u9fa5]")

    p = optparse.OptionParser(usage="usage: %prog [options] arg1 arg2", version="%prog 0.1", prog="url-tagger")
    p.add_option("--url", "-u", help="Your url")
    p.add_option("--file", "-f", help="Your url file. One line one url")
    (options, arguments) = p.parse_args()

    url_list = []
    for key, value in options.__dict__.items():
        if value is not None:
            print("%s: %s" % (key, value))
            if key is "url":
                url_list.append(value)
            else:
                url_file = open(value, "rb+")
                for line in url_file.readlines():
                    url_list.append(str(line, encoding="utf-8").strip())


    # 异步发起http请求
    @asyncio.coroutine
    def get_docs(url):
        response = requests.get(url=url, headers={'Accept-Encoding': ''})
        # print(response.apparent_encoding)
        html = str(response.content, encoding=response.apparent_encoding, errors="ignore")
        soup = BeautifulSoup(html, "lxml")
        for script in soup(["script", "style"]):
            script.extract()
        text = soup.get_text()
        lines = (line.strip() for line in text.splitlines())
        chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
        text = "".join(chunk for chunk in chunks if chunk)
        # print(text)
        return url, text

    loop = asyncio.get_event_loop()
    tasks = list(map(lambda url: asyncio.ensure_future(get_docs(url)), url_list))
    data_list = list(loop.run_until_complete(asyncio.gather(*tasks)))
    loop.close()

    # 分类器进行分类
    results = [(url, classifier.classify(find_features(jieba.lcut("".join(regex.findall(data)))))) for (url, data)
               in data_list]

    # 打印结果
    for (url, category) in results:
        print("%s: %s" % (url, category))

