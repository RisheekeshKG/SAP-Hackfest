"""
Configuration module for the Verilog Verification Agent
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


class Config:
    """Configuration settings for the agent"""
    
    # API Keys
    GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
    
    # Agent Settings
    MAX_ITERATIONS = int(os.getenv("MAX_ITERATIONS", "3"))   # keep lower to save quota

    # Model Settings — override via GEMINI_MODEL env var
    # Free tier quotas (requests/day):
    #   gemini-1.5-flash  → 1,500/day  ✅ recommended
    #   gemini-2.0-flash  → 200/day
    #   gemini-2.5-flash  → 20/day     (too low for CI use)
    MODEL_NAME  = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
    TEMPERATURE = 0.2
    
    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    
    @classmethod
    def validate(cls):
        """Validate that required configuration is present"""
        if not cls.GOOGLE_API_KEY:
            raise ValueError(
                "GOOGLE_API_KEY not found. "
                "Please set it in your .env file or environment variables."
            )
        return True

# Validate configuration on import
Config.validate()

