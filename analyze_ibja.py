import urllib.request
import re
import json

req = urllib.request.Request('https://ibjarates.com/', headers={'User-Agent': 'Mozilla/5.0'})
html = urllib.request.urlopen(req).read().decode('utf-8')

print("Links:")
links = re.findall(r'href="([^"]+)"', html)
for l in links:
    if 'api' in l or 'json' in l or 'php' in l:
        print(l)
        
print("Scripts:")
scripts = re.findall(r'src="([^"]+)"', html)
for s in scripts:
    print(s)

print("Any JSON inside HTML:")
# Find json looking strings
for match in re.findall(r'\{.*\}', html):
    if len(match) > 10 and '999' in match:
        print(match[:200])
