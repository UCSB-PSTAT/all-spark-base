c.ServerProxy.servers = {
    "spark_ui": {
        "command" : ["python3", "-c", "from pyspark.context import SparkContext; SparkContext()"],
        "port" : 4040,
        "absolute_url": False,
        "timout" : 3600,
        "launcher_entry": {
                "enabled": True,
                "icon_path": "/opt/spark-logo-rev.svg",
                "title": "Spark UI",
                "path_info": "spark_ui/jobs/"
        },
        "new_browser_tab": False
    }
}
