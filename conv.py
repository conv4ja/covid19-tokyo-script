#!/usr/bin/python3

import pandas as pd
import numpy as np
import json
from pathlib import Path
from datetime import date, timedelta

def scan_and_get(startAt, endAt):
    data_series = {}
    data_series_raw = {}
    prefix = "out/"
    fname = "/patient-mod.json"
    skip_days = 0
    d = startAt
    d_seq = str(d)
    target = prefix + d_seq + fname
    data = pd.read_json(target)
    data_series[d_seq] = data
    data_series_raw[d_seq] = data
    while d <= endAt:
        print(target)
        d_prev = str(d - timedelta(skip_days))
        d += timedelta(1)
        d_seq = str(d)
        target = prefix + d_seq + fname
        if Path(target).is_file() != False:
            data = pd.read_json(target)
            data_series_raw[d_seq] = data
            data_series[d_seq] = data
            skip_days = 0
        else:
            skip_days += 1
    return data_series


def main():
    initial_day = date(2020,6,1)
    today = date(1900,1,1).today()
    dataset = scan_and_get(startAt = initial_day, endAt = today )
    dataset_mod = {}
    init = "2020-06-01"
    df_main = dataset[init][["label","count"]].copy()
    df_main.columns = ["label",init]
    i_prev = init
    for i in dataset:
        dataset[i] = dataset[i][["label","count"]]
        dataset[i].columns = ["label",i]
        if i != init:
            dataset_mod[i] = dataset[i].copy()
            dataset_mod[i][i] = dataset[i][i] - dataset[i_prev][i_prev]
            df_main = pd.merge(df_main, dataset_mod[i], how="left", on="label")
        i_prev = i
    label = df_main["label"]
    df_main = df_main.drop(columns=["label"])
    df = df_main.transpose()
    df.columns = label
    df.to_csv("./data-raw.csv")

main()
