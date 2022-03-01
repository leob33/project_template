DOCKER_IMAGE_CI = project_template_ci
DOCKER_IMAGE_PACKAGING = project_template_packaging
TEST_FOLDER = tests
SRC_FOLDER = project_name

# ================= CI docker image =================

docker-image-rm:
	docker image rm -f $(DOCKER_IMAGE_CI)

docker-build: docker-image-rm
	docker build --file dockerfiles/Dockerfile_for_ci -t $(DOCKER_IMAGE_CI) .

# docker container run
docker-run:
	docker run -it --rm --entrypoint /bin/bash $(DOCKER_IMAGE_CI)

# ================= TEST in CI conditions =================

simulate-ci:
	docker run -it --rm --entrypoint make $(DOCKER_IMAGE_CI) ci

ci: mypy flake8 test-python build-wheel

# +++++++++ TESTS ++++++++

test-python:
	PYTHONPATH=. pytest -rA --cov-report html:reports/ --cov=gilded_rose  tests

flake8:
	flake8 $(SRC_FOLDER) $(TEST_FOLDER)

mypy:
	-mypy $(SRC_FOLDER) $(TEST_FOLDER) # we - to ignore if there is an error

# +++++++++ PACKAGING ++++++++

build-wheel:
	python -m build --wheel

install-wheel:
	pip install dist/$(SRC_FOLDER)-1.0.0-py3-none-any.whl

# ================= OTHER USEFUL COMMAND =================

install-package-normal:
	pip install .

install-package-devmode:
	pip install -e '.[dev]' # install extra labelled dev dependencies

clean:
	rm -rf build dist .pytest_cache $(SRC_FOLDER).egg-info reports .coverage

uninstall-all:
	pip freeze | xargs pip uninstall -y
