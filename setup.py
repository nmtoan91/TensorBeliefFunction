import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="TensorBeliefFunction", 
    version="0.0.3",
    author="nmtoan91",
    author_email="toan_stt@yahoo.com",
    description="Tensor of Belief Function",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/nmtoan91/TensorBeliefFunction",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)