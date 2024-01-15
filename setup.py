from setuptools import setup, find_packages

with open("requirements.txt") as f:
    required = f.read().splitlines()

setup(
    name="runwhen-public-keywords",
    version=open("VERSION").read(),
    packages=["RW"],
    package_dir={"RW": "RW"},
    license="Apache License 2.0",
    description="A set of RunWhen published keywords for interacting with various APIs.",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Kyle Forster",
    author_email="kyle.forster@runwhen.com",
    url="https://github.com/runwhen-contrib/rw-public-codecollection",
    install_requires=required,
    include_package_data=True,
    classifiers=["Programming Language :: Python :: 3", "License :: OSI Approved :: Apache Software License"],
)
