import glob
import subprocess

# Loop through all .sh files in the ag8 directory
for script in glob.glob('ag8/*.sh'):
    try:
        # Execute the script and capture the output
        output = subprocess.run(['bash', script], capture_output=True, text=True, check=True)
        
        # Get the last line of the output
        last_line = output.stdout.strip().split('\n')[-1] if output.stdout else ''
        
        # Print the last line if it's not empty
        if last_line:
            print(last_line)
    except subprocess.CalledProcessError as e:
        print(f"Error executing {script}: {e}")
    