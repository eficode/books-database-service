#!/usr/bin/env python3
"""
GDPR Data Cleanup Script
Automatically deletes personal data that has exceeded its retention period
Should be run daily via cron job for GDPR compliance
"""

import sys
import os
from datetime import datetime, timezone, timedelta

# Add the parent directory to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi_demo.database import SessionLocal, engine
from fastapi_demo.models import Gift, GiftDataAccess
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

def cleanup_expired_gift_data():
    """
    Delete gift orders that have exceeded their retention period
    GDPR Article 5(1)(e) - storage limitation principle
    """
    db = SessionLocal()
    try:
        # Find gifts that have expired
        expired_gifts = db.query(Gift).filter(
            Gift.data_retention_until <= datetime.now(timezone.utc),
            Gift.data_retention_until.isnot(None)
        ).all()
        
        deletion_count = 0
        for gift in expired_gifts:
            print(f"Deleting expired gift order #{gift.id} (expired: {gift.data_retention_until})")
            
            # Log the automated deletion for audit trail
            log_entry = GiftDataAccess(
                gift_id=gift.id,
                access_type="AUTO_DELETE",
                accessed_by="data_cleanup_script",
                access_purpose="gdpr_data_retention_enforcement",
                ip_address="system",
                user_agent="cleanup_script"
            )
            db.add(log_entry)
            
            # Delete the gift order
            db.delete(gift)
            deletion_count += 1
        
        if deletion_count > 0:
            db.commit()
            print(f"Successfully deleted {deletion_count} expired gift orders")
        else:
            print("No expired gift orders found")
            
    except Exception as e:
        print(f"Error during cleanup: {e}")
        db.rollback()
    finally:
        db.close()

def cleanup_old_audit_logs():
    """
    Clean up audit logs older than 2 years (regulatory requirement)
    Keep audit trail but not indefinitely
    """
    db = SessionLocal()
    try:
        cutoff_date = datetime.now(timezone.utc) - timedelta(days=730)  # 2 years
        
        old_logs = db.query(GiftDataAccess).filter(
            GiftDataAccess.timestamp <= cutoff_date
        ).all()
        
        log_count = len(old_logs)
        if log_count > 0:
            for log in old_logs:
                db.delete(log)
            
            db.commit()
            print(f"Deleted {log_count} old audit log entries")
        else:
            print("No old audit logs to clean up")
            
    except Exception as e:
        print(f"Error cleaning up audit logs: {e}")
        db.rollback()
    finally:
        db.close()

def generate_compliance_report():
    """
    Generate a compliance report showing data retention status
    """
    db = SessionLocal()
    try:
        # Count active gifts
        active_gifts = db.query(Gift).filter(
            Gift.data_retention_until > datetime.now(timezone.utc)
        ).count()
        
        # Count gifts without retention dates (legacy data)
        legacy_gifts = db.query(Gift).filter(
            Gift.data_retention_until.is_(None)
        ).count()
        
        # Count recent deletions
        recent_deletions = db.query(GiftDataAccess).filter(
            GiftDataAccess.access_type == "AUTO_DELETE",
            GiftDataAccess.timestamp >= datetime.now(timezone.utc) - timedelta(days=7)
        ).count()
        
        print("\n=== GDPR Compliance Report ===")
        print(f"Active gift orders: {active_gifts}")
        print(f"Legacy gift orders (no retention date): {legacy_gifts}")
        print(f"Auto-deletions in last 7 days: {recent_deletions}")
        print(f"Report generated: {datetime.now(timezone.utc).isoformat()}")
        
        if legacy_gifts > 0:
            print(f"\nWARNING: {legacy_gifts} gift orders have no retention date.")
            print("Consider migrating these to set appropriate retention periods.")
        
    except Exception as e:
        print(f"Error generating compliance report: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Starting GDPR data cleanup...")
    print(f"Current time: {datetime.now(timezone.utc).isoformat()}")
    
    # Run cleanup tasks
    cleanup_expired_gift_data()
    cleanup_old_audit_logs()
    generate_compliance_report()
    
    print("GDPR data cleanup completed.")
