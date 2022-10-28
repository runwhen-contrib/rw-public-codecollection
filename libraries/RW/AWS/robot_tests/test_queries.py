SAMPLE_METRIC_QUERY = {
    "view": "timeseries",
    "regon": "us-west-1",
    "metrics": [
        {"expression": "SELECT MAX(CPUUtilization) FROM \"AWS/EC2\""},
    ]
}