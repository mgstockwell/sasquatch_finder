# [START gae_python3_app]
from flask import Flask
import os
import json
import datetime
import folium
from google.cloud import bigquery
from google.oauth2 import service_account

# logon and get credentials.
if os.getenv('GAE_ENV', '').startswith('standard'):
  # Production in the standard environment
  client = bigquery.Client()
else:
  # Local execution.
    key_path = "c:\\tmp\\msd8654-434-c23b2877795f.json"
    credentials = service_account.Credentials.from_service_account_file(
        key_path, scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    client = bigquery.Client(credentials=credentials, project=credentials.project_id,)

# Get data from BQ

def query_bfro():
    #client = bigquery.Client()
    query_job = client.query(
        """
        SELECT
        CENTROID_ID,
        CENTROID_COLOR,
        county,
        state,
        season,
        latitude,
        longitude,
        elevation,
        date,
        number,
        terrain_type, climate_type,
        CONCAT('<a href="https://www.bfro.net/gdb/show_report.asp?id=', number,'">BFRO report</a><br>h:',
        hardiness_zone_code,'<br>elv:',elevation,'<br>type:',climate_type,terrain_type) link
        FROM
        `bfro.bf_centroids_sample_vv`
        WHERE
        latitude IS NOT NULL
        AND partition_rnk <100
        """
    )

    results = query_job.result()  # Waits for job to complete.
    return results

# If `entrypoint` is not defined in app.yaml, App Engine will look for an app
# called `app` in `main.py`.
app = Flask(__name__)

@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    msg = {
        "timestamp": str(datetime.datetime.now()),
        "msg": 'Hello World!'
    }
    return json.dumps(msg)


@app.route('/map')
def index():
    start_coords = (36.00, -95.00)
    folium_map = folium.Map(location=start_coords, zoom_start=5)
    # icon = folium.features.CustomIcon('https://icon-library.com/2993760.html', icon_size=(24, 24))

    # add markers for each sighting
    
    for row in query_bfro():
        folium.Marker(
        location=[row.latitude, row.longitude],
        popup=row.link,
        icon=folium.Icon(color=row.CENTROID_COLOR_GEO)
    ).add_to(folium_map)

    return folium_map._repr_html_()

@app.route('/map2')
def index2():
    start_coords = (36.00, -95.00)
    folium_map = folium.Map(location=start_coords, zoom_start=5)
    # icon = folium.features.CustomIcon('https://icon-library.com/2993760.html', icon_size=(24, 24))

    # add markers for each sighting
    
    for row in query_bfro():
        folium.Marker(
        location=[row.latitude, row.longitude],
        popup=row.link,
        icon=folium.Icon(color=row.CENTROID_COLOR_CLIMATE)
    ).add_to(folium_map)

    return folium_map._repr_html_()

@app.route('/map3')
def index3():
    start_coords = (36.00, -95.00)
    folium_map = folium.Map(location=start_coords, zoom_start=5)
    # icon = folium.features.CustomIcon('https://icon-library.com/2993760.html', icon_size=(24, 24))

    # add markers for each sighting
    
    for row in query_bfro():
        folium.Marker(
        location=[row.latitude, row.longitude],
        popup=row.link,
        icon=folium.Icon(color=row.CENTROID_COLOR_GEO_CLIMATE)
    ).add_to(folium_map)

    return folium_map._repr_html_()

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. You
    # can configure startup instructions by adding `entrypoint` to app.yaml.
    app.run(host='127.0.0.1', port=8080, debug=True)
# [END gae_python3_app]
# [END gae_python38_app]
