import pandas as pd

routes = ["Northern", "Central", "Circle", "District", "Jubilee"]

trains = pd.DataFrame({
    "route":   pd.Categorical(routes, categories=routes, ordered=True),
    "on_time": [142, 98, 201, 87, 165],
    "total":   [154, 110, 215, 95, 178],
})
trains["rate"] = trains["on_time"] / trains["total"] * 100
