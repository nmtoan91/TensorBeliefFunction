load bmshaferex
allbel = [BELIEF(:).number]
d = discount(2, .25)
newbel = [setdiff(allbel, 2) d]
embedbel = condiembed(newbel)
keepbel(embedbel)
showbel(solve('Bloodtest Ploxoma'))
addevid1 = [embedbel observe('Bloodtest', 'x2')];
showbel(solve(addevid1, 'Ploxoma'))
addevid2 = [embedbel observe('Bloodtest', 'x1')];
showbel(solve(addevid2, 'Ploxoma'))
addevid3 = [embedbel observe('Bloodtest', 'x3')];
showbel(solve(addevid3, 'Ploxoma'))