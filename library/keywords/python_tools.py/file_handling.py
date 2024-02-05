import os
import glob
from robot.api.deco import keyword

@keyword("Get Latest Matching File")
def get_latest_matching_file(folder: str, pattern: str) -> str:

    files = glob.glob(os.path.join(folder, pattern))
    return max(files, key=os.path.getctime) if files else None
