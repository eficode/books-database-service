from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Dict
from ..database import get_db
from ..models import SalesData
from ..dtos import SalesFilter, SalesReportResponse, YTDSalesResponse, FilteredSales

router = APIRouter(
    prefix="/sales",
    tags=["sales"]
)

@router.get("/ytd", response_model=YTDSalesResponse, summary="Get YTD sales data", description="Fetches the year-to-date sales data for the current and previous year.")
def get_ytd_sales(db: Session = Depends(get_db)):
    from datetime import date, timedelta
    import calendar
    today = date.today()
    current_year = today.year
    previous_year = current_year - 1

    def get_sales_data(year):
        sales_by_month = []
        total_sales = 0.0
        for month in range(1, 13):
            start_date = date(year, month, 1)
            end_date = date(year, month, calendar.monthrange(year, month)[1])
            monthly_sales = db.query(SalesData).filter(SalesData.date >= start_date, SalesData.date <= end_date).all()
            month_sales_total = sum(sale.sales for sale in monthly_sales)
            sales_by_month.append({"month": calendar.month_name[month], "sales": month_sales_total})
            total_sales += month_sales_total
        return {"total_sales": total_sales, "sales_by_month": sales_by_month}

    current_year_sales = get_sales_data(current_year)
    previous_year_sales = get_sales_data(previous_year)
    return {"current_year": current_year_sales, "previous_year": previous_year_sales}

@router.get("/filter", response_model=Dict[str, List[FilteredSales]], summary="Filter sales data", description="Fetches the sales data based on the provided filters such as date range, product category, and region.")
def filter_sales(date_range: str, product_category: str, region: str, db: Session = Depends(get_db)):
    from datetime import datetime
    start_date, end_date = date_range.split(" to ")
    start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
    end_date = datetime.strptime(end_date, "%Y-%m-%d").date()
    sales = db.query(SalesData).filter(SalesData.date >= start_date, SalesData.date <= end_date)
    if product_category:
        sales = sales.filter(SalesData.product_category == product_category)
    if region:
        sales = sales.filter(SalesData.region == region)
    sales = sales.all()
    return {"filtered_sales": [{"date": sale.date.isoformat(), "category": sale.product_category, "region": sale.region, "sales": sale.sales} for sale in sales]}

@router.post("/report", response_model=SalesReportResponse, summary="Generate sales report", description="Generates a sales performance report including insights and trends explaining the YTD sales performance.")
def generate_sales_report(db: Session = Depends(get_db)):
    import uuid
    report_id = str(uuid.uuid4())
    report_url = f"/reports/{report_id}"
    # Logic to generate report and save it to a file or database can be added here
    return {"report_id": report_id, "report_url": report_url}
