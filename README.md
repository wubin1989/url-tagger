# url-tagger
A command line tool for tagging url written by python.
Only for self-learning

# features
1. use nltk naivebayes algorithm for text classification
2. use sougou news corpus of 9 classes (health, military, sport, culture, economy, education, internet, recruit, travel)
3. use asyncio coroutine to requrest each url concurrently

# requirements
python 3.3–3.5
pip3

# setup
pip3 install -r requirements.txt

# usage
1. git clone git@github.com:wubin1989/url-tagger.git
2. cd url-tagger
3. ./app -h
4. ./app -u "http://sports.qq.com/"
5. ./app -f "/Users/a1/oopdata/mypython/url-tagger/test_urls.txt"

# todo
1. improve classifier
2. ...
