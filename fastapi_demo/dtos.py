from pydantic import BaseModel
from typing import List, Dict

class SalesByMonth(BaseModel):
    month: str
    sales: float

class YTDSalesResponse(BaseModel):
    current_year: Dict[str, List[SalesByMonth]]
    previous_year: Dict[str, List[SalesByMonth]]

class FilteredSales(BaseModel):
    date: str
    category: str
    region: str
    sales: float

class SalesFilter(BaseModel):
    date_range: str
    product_category: str
    region: str

class SalesReportResponse(BaseModel):
    report_id: str
    report_url: str
