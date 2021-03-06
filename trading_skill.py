import urllib.request
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

participants = [
    ("MarcinMC", "https://www.forexfactory.com/marcinmc#acct.40-tab.report"),
    ("twardy", "https://www.forexfactory.com/twardy#acct.97-tab.report"),
    ("KRZYSSS-ZIELONAGORA", "https://www.forexfactory.com/krzysss#acct.53-tab.report"),
    ("Sakuraba", "https://www.forexfactory.com/sakuraba#acct.63-tab.report"),
    ("xsajanin", "https://www.forexfactory.com/xsajanin#acct.72-tab.report"),
    ("Szacher Mache", "https://www.forexfactory.com/langusta#acct.15-tab.report"),
    ("Paweł Szwajcar Fx", "https://www.forexfactory.com/szwajcar#acct.58-tab.report"),
    ("Trader 9", "https://www.forexfactory.com/tradingskill#acct.83-tab.report"),
    ("OGRODNIK", "https://www.forexfactory.com/artur012#acct.79-tab.report"),
    ("PKO24", "https://www.forexfactory.com/pko24#acct.63-tab.report"),
    ("Wodnik Szuwarek", "https://www.forexfactory.com/jorzinzbazin#acct.09-tab.report"),
    ("PhillBear", "https://www.forexfactory.com/phillbear#acct.76-tab.report"),
    ("błędny rycerz", "https://www.forexfactory.com/blednyrycerz#acct.19-tab.report"),
    ("Dymek", "https://www.forexfactory.com/dymek#acct.76-tab.report"),
    ("kopczyniak", "https://www.forexfactory.com/kopczyniak#acct.36-tab.report"),
    ("pafnucy", "https://www.forexfactory.com/pafnucy#acct.79-tab.report"),
    ("szpenio", "https://www.forexfactory.com/szpenio#acct.51-tab.report"),
    ("PabloN", "https://www.forexfactory.com/pablon#acct.41-tab.report"),
    ("Leon Fx", "https://www.forexfactory.com/fxleonfx#acct.36-tab.report"),
    ("Vezoriwariat", "https://www.forexfactory.com/vezoriwariat#acct.91-tab.report"),
    ("Rafał‚ Zaorski (OFICJALNIE)", "https://www.forexfactory.com/deskorolkarz#acct.23-tab.report"),
    ("Maksymilian Bączkowski (OFICJALNIE)", "https://www.forexfactory.com/mixmax#acct.24-tab.report"),
    ("Fisio11", "https://www.forexfactory.com/fisio11#acct.69-tab.report"),
    ("Krystianlas", "https://www.forexfactory.com/krystianlas#acct.47-tab.report"),
    ("Mariusz", "https://www.forexfactory.com/mariowymiata#acct.79-tab.report"),
    ("Wiedźma", "https://www.forexfactory.com/wiedzma#acct.64-tab.report"),
    ("Seba", "https://www.forexfactory.com/seba77#acct.39-tab.report"),
    ("PalcemPoWodzie", "https://www.forexfactory.com/96maro#acct.11-tab.report"),
    ("Kamil Partyka (OFICJALNIE)", "https://www.forexfactory.com/kamilpartyka#acct.83-tab.report"),
    ("Radosław Rygielski (OFICJALNIE)", "https://www.forexfactory.com/rral#acct.06-tab.report"),
    ("KonradSz-n", "https://www.forexfactory.com/konradsz-n#acct.46-tab.report"),
    ("Smart Sęp (OFICJALNIE)", "https://www.forexfactory.com/smartsep#acct.00-tab.report"),
    ("Marcin Tuszkiewicz (OFICJALNIE)", "https://www.forexfactory.com/ttusiek#acct.69-tab.report"),
    ("Temet Nosce (OFICJALNIE)", "https://www.forexfactory.com/temet.io#acct.31-tab.report"),
    ("Aurum", "https://www.forexfactory.com/tradingskill#acct.52-tab.report"),
    ("Q3master", "https://www.forexfactory.com/arturo#acct.68-tab.report"),
    ("Erik0", "https://www.forexfactory.com/erik0#acct.60-tab.report"),
    ("acdc-tnt", "https://www.forexfactory.com/pwr-up#acct.09-tab.report"),
    ("Powoli do przodu", "https://www.forexfactory.com/sizar#acct.38-tab.report"),
    ("Trader 41", "https://www.forexfactory.com/tradingskill#acct.41-tab.report"),
    ("Gracz-Fx", "https://www.forexfactory.com/gracz-fx#acct.93-tab.report"),
    ("ZŁOTNIK87", "https://www.forexfactory.com/zlotnik87#acct.77-tab.report"),
    ("Sebizbir", "https://www.forexfactory.com/sebizbir#acct.24-tab.report"),
    ("Dla żony", "https://www.forexfactory.com/matg86#acct.37-tab.report"),
    ("DargoFx", "https://www.forexfactory.com/degorbi#acct.18-tab.report"),
    ("Tańczący z jeżami", "https://www.forexfactory.com/k-roll#acct.30-tab.report"),
    ("swiezak", "https://www.forexfactory.com/swiezak#acct.71-tab.report"),
    ("Roberto Fuego", "https://www.forexfactory.com/robertofuego#acct.29-tab.report"),
    ("BANKRUT999", "https://www.forexfactory.com/mario141194#acct.63-tab.report"),
    ("Staeb", "https://www.forexfactory.com/staeb#acct.52-tab.report"),
    ("Trade 2021", "https://www.forexfactory.com/jerryw#acct.38-tab.report"),
    ("marekuss", "https://www.forexfactory.com/marekuss#acct.23-tab.report"),
    ("GrekZajadacz", "https://www.forexfactory.com/grekzajadacz#acct.33-tab.report"),
    ("krakus", "https://www.forexfactory.com/euroforex#acct.34-tab.report"),
    ("MCH", "https://www.forexfactory.com/mathi#acct.77-tab.report"),
    ("Czysty wykres", "https://www.forexfactory.com/brtrfx#acct.99-tab.report"),
    ("Trader 58", "https://www.forexfactory.com/tradingskill#acct.14-tab.report"),
    ("rafii", "https://www.forexfactory.com/rafal.cze#acct.70-tab.report"),
    ("Wilk z Bieszczad", "https://www.forexfactory.com/wilkzbiesow#acct.94-tab.report"),
    ("murcielago77", "https://www.forexfactory.com/baracsedart#acct.70-tab.report"),
    ("Diament", "https://www.forexfactory.com/diament#acct.24-tab.report"),
    ("RadekZG", "https://www.forexfactory.com/tradingskill#acct.81-tab.report"),
    ("Fast TS6", "https://www.forexfactory.com/fastdriver#acct.22-tab.report"),
    ("Trader 65", "https://www.forexfactory.com/kamasz7#acct.98-tab.report"),
    ("Trader 66", "https://www.forexfactory.com/tradingskill#acct.16-tab.report"),
    ("Thomas5648", "https://www.forexfactory.com/thomas5648#acct.47-tab.report"),
    ("CieńMgły", "https://www.forexfactory.com/ziew#acct.89-tab.report"),
    ("Trader 69", "https://www.forexfactory.com/sita1#acct.31-tab.report"),
    ("DonVitoCorleone", "https://www.forexfactory.com/donvitocorle#acct.99-tab.report"),
    ("Dominus", "https://www.forexfactory.com/dranet#acct.36-tab.report"),
    ("biotiq", "https://www.forexfactory.com/biotiq#acct.97-tab.report"),
]

explorer_api = "https://www.forexfactory.com/explorerapi.php?content=tradereport&id="

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36"
}

html_top = \
r"""
<!DOCTYPE html><html lang="en"><head><base href="/"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><title>Trading Skill</title><link rel="stylesheet" href="https://kit-free.fontawesome.com/releases/latest/css/free.min.css"><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css" integrity="sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2" crossorigin="anonymous"><link rel="stylesheet" href="https://unpkg.com/bootstrap-table@1.18.2/dist/bootstrap-table.min.css"> <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.min.js"></script> </head><body><table id="table" data-toolbar=".toolbar"><thead><tr><th data-field="name">Name</th><th data-field="roi" data-sortable="true">Return %</th><th data-field="profit" data-sortable="true">Profit $</th><th data-field="equity" data-sortable="true">Equity $</th><th data-field="net_transfers" data-sortable="true">Net Transfers $</th></tr></thead></table><script>var data = ["""

html_bottom = \
r"""]
var $table = $('#table')
$(function(){$table.bootstrapTable({data: data,sortStable: true,sortName:'roi',sortOrder: 'desc'})})</script><script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ho+j7jyWK8fNQe+A12Hb8AhRq26LrZ/JpcUGGOn+Y7RsweNrtN/tE3MoK7ZeZDyx" crossorigin="anonymous"></script> <script src="https://unpkg.com/bootstrap-table@1.18.2/dist/bootstrap-table.min.js"></script> </body></html>"""

extract_account = re.compile(r"\.(\d+)-")
extract_explorer_id = re.compile(r"from_(\d+)")
extract_funds = re.compile(r'explorer_tradereport__total\\">\\n\\n.*?[\$;]([\-\d,\.]+)')
extract_roi = re.compile(r"([\-\d,\.]+)%")

print(html_top)

for name, url in participants:
    req = urllib.request.Request(url, data=None, headers=headers)
    page = urllib.request.urlopen(req).read().decode("utf-8", "ignore")

    account = extract_account.search(url).group(1)
    position = page.find("X" + account)
    page = page[position:]
    match = extract_explorer_id.search(page)
    if match and (position > 0):
        req = urllib.request.Request(explorer_api + match.group(1), data=None, headers=headers)
        try:
            page = urllib.request.urlopen(req).read().decode("utf-8", "ignore")
        except urllib.error.HTTPError as e:
            print("{{name:'<a href=\"{}\" target=\"_blank\" rel=\"noopener noreferrer\">{}</a>', roi:0, profit:0, equity:0, net_transfers:0}},".format(url, name))
            continue
        roi = float(extract_roi.search(page).group(1).replace(",", ""))
        funds = extract_funds.findall(page)
        equity = 0
        net_transfers = 0
        if len(funds) >= 2:
            equity = float(funds[0].replace(",", ""))
            net_transfers = float(funds[1].replace(",", ""))
        profit = equity - net_transfers
        print("{{name:'<a href=\"{}\" target=\"_blank\" rel=\"noopener noreferrer\">{}</a>', roi:{:.2f}, profit:{:.2f}, equity:{:.2f}, net_transfers:{:.2f}}},".format(url, name, roi, profit, equity, net_transfers))
    else:
        print("{{name:'<a href=\"{}\" target=\"_blank\" rel=\"noopener noreferrer\">{}</a>', roi:0, profit:0, equity:0, net_transfers:0}},".format(url, name))

print(html_bottom)
