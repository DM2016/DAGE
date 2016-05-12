#!/usr/bin/env python
__author__ = 'dichenli'

from setuptools import setup

setup(name='dageboot',
      version='0.1.5',
      description='DAGE cassandra bootstrap tool',
      long_description='DAGE cassandra bootstrap tool...',
      url='https://github.com/dichenli/DAGE',
      author='dichenli',
      author_email='dichenldc@gmail.com',
      license='MIT',
      packages=['dageboot'],
      zip_safe=True,
      entry_points={
          'console_scripts': [
              'dageboot = dageboot.__main__:main'
          ]
      },
      install_requires=[
          'boto3',
          'paramiko',
          'aenum',
          'scp',
          'argparse'
      ],
      include_package_data=True
      )
