setup:
	python3 -m venv ~/.myrepo

install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

create_gcp_project:
	gcloud-setup.sh

load_data:
	bq mk bfro
	./load_data/load_data.py

test:
	python -m pytest -vv --cov=myrepolib tests/*.py
	python -m pytest --nbval notebook.ipynb

lint:
	pylint --disable=R,C myrepolib cli web

all: install lint test
