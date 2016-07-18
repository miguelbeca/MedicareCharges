### FluCharges.py
import cx_Oracle
from bs4 import BeautifulSoup


##Get Data
flucharges = {}

##Oracle database connection
oracle_conn = cx_Oracle.connect('User/Password@host/OracleSID') ##Use appropriate connection string
oracle_cursor = oracle_conn.cursor()
oracle_insert = oracle_conn.cursor()

oracle_cursor.execute('SELECT FIPS_STATE_STRING,FIPS_CO,MEDIAN_CHARGES FROM FLUCHARGES')
while 1:
    oracle_row = oracle_cursor.fetchone()
    if not oracle_row:
        break
    fips_state =  str(oracle_row[0])
    fips_county = str(oracle_row[1])
    full_fips = fips_state + fips_county
    charges = float(oracle_row[2])
    flucharges[full_fips] = charges


oracle_cursor.close()
oracle_insert.close()
oracle_conn.close()

# Load the SVG map
svg = open('USA_Counties_with_FIPS_and_names.svg', 'r').read()

# Load into Beautiful Soup
soup = BeautifulSoup(svg, 'xml')

# Find counties
paths = soup.findAll('path')

# Map colors
colors = ["#eff3ff","#bdd7e7","#6baed6","#3182bd","#08519c"]


# County style
path_style = 'font-size:12px;fill-rule:nonzero;stroke:#FFFFFF;stroke-opacity:1;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-linecap:butt;marker-start:none;stroke-linejoin:bevel;fill:'

# Pick appropriate color for each county based on flu charges 
for p in paths:

    if p['id'] not in ["State_Lines", "separator"]:
        try:
            rate = flucharges[p['id']]
        except:
            continue
        if rate > 65.06:
            color_class = 4
        elif rate > 50.05:
            color_class = 3
        elif rate > 35.03:
            color_class = 2
        elif rate > 20.02:
            color_class = 1
        else:
            color_class = 0
        color = colors[color_class]
        p['style'] = path_style + color

##Save output to new SVG file
final_file = open('Flu_Charges_Median_Map_vFinal.svg', 'w')
final_file.write(soup.prettify())
final_file.close()
