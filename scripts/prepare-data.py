#!/usr/bin/env python

import argparse
import pandas as pd
import uuid

parser = argparse.ArgumentParser()
parser.add_argument("source_file")
parser.add_argument("target_file")
args = parser.parse_args()

# Simple table-scoped anonymization.

anonymized = {}


def anonymize(input):
    if pd.isnull(input):
        return input
    return anonymized.setdefault(input, str(uuid.uuid4()))


# Read data.
df = pd.read_csv(args.source_file)

# Normalize timestamps to an ISO8601 string.
for column in df.filter(regex="_at$").columns:
    # Fix missing fractional parts.
    df[column] = df[column].str.replace(r"(?<=:\d\d)(?=\+)", ".0", regex=True)
    # Parse as datetime and convert to ISO format.
    df[column] = pd.to_datetime(df[column]).apply(lambda t: t.isoformat())

# Anonymize columns in a whitelist.
for column in df.filter(items=["email"]):
    df[column] = df[column].apply(anonymize)

# Write data.
df.to_csv(args.target_file, index=False)
