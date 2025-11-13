#!/usr/bin/env python3
"""
AI Mail - Application for automated email processing with AI
"""
import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def main():
    """Main application entry point"""
    print("AI Mail application starting...")
    
    # Check if required environment variables are set
    required_vars = ['OPENAI_API_KEY', 'EMAIL_USERNAME', 'EMAIL_PASSWORD']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}")
        print("Please create a .env file based on .env.example")
        sys.exit(1)
    
    print("Configuration loaded successfully!")
    # Add your application logic here

if __name__ == "__main__":
    main()

