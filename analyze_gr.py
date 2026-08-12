import urllib.request
import re

url = "https://www.goodreturns.in/gold-rates/india.html"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    print("GoodReturns HTML fetched, length:", len(html))
    
    # Check for any json or api links
    links = re.findall(r'href="([^"]+)"', html)
    for l in links:
        if 'api' in l or 'json' in l:
            print("Link:", l)
            
except Exception as e:
    print("Error:", e)
