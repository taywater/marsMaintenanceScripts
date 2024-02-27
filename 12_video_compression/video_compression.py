#Directory structure crawl

import os, pandas as pd
import subprocess
import re

def list_files(path, ext):
    paths = []
    bitrates = []
    framerates = []
    sizes = []
    size = 0

    #walk the specified directory
    for root, dirs, files in os.walk(path):
        for file in files:

            #if the lowercase file extension of a file matches the specified ext
            if file.lower().endswith(ext.lower()):
                paths.append(os.path.join(root, file))
                print(file.lower()+": " + str(((os.stat(os.path.join(root, file)).st_size)/1024/1024)))
                size = size + ((os.stat(os.path.join(root, file)).st_size)/1024/1024)
                metadata_command = "ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate,r_frame_rate -of default=noprint_wrappers=1 \"" + os.path.join(root, file) + "\""
                metadata_res = subprocess.check_output(metadata_command, shell=True)
                metadata_tup = re.split('\r|=',metadata_res)
                bitrate = eval(metadata_tup[3])/1024
                bitrates.append(bitrate)
                framerates.append(metadata_tup[1])
                sizes.append((os.stat(os.path.join(root, file)).st_size)/1024)
                print(str(len(paths)) + " files found with extension " + ext)
                print("total file size: " + str(round(size/1024, 3)) + " GB")
    return(paths, bitrates,framerates,sizes)


mp4s = list_files("C:\\Users\\brian.cruice\\Desktop\\test videos\\script test", "mp4")
mp4_dict = {'path': mp4s[0],'bitrate (kbps)': mp4s[1],'framerate': mp4s[2],'Size (Kbs)': mp4s[3]}
mp4_df = pd.DataFrame(mp4_dict)
#mp4_df.to_csv('O:\\Watershed Sciences\\GSI Monitoring\\01 Admin\\08 Databases and Digital Resources\\01 Good Housekeeping\\Video Compression Comparison\\server_mp4.csv')

movs = list_files("C:\\Users\\brian.cruice\\Desktop\\test videos\\script test", "mov")
mov_dict = {'path': movs[0],'bitrate (kbps)': movs[1],'framerate': movs[2],'Size (Kbs)': movs[3]}
mov_df = pd.DataFrame(mov_dict)
#mov_df.to_csv('O:\\Watershed Sciences\\GSI Monitoring\\01 Admin\\08 Databases and Digital Resources\\01 Good Housekeeping\\Video Compression Comparison\\server_mov.csv')

heics = list_files("C:\\Users\\brian.cruice\\Desktop\\test videos\\script test", "heic")
heic_dict = {'path': heics[0],'bitrate (kbps)': heics[1],'framerate': heics[2],'Size (Kbs)': heics[3]}
heic_df = pd.DataFrame(heic_dict)
#heic_df.to_csv('O:\\Watershed Sciences\\GSI Monitoring\\01 Admin\\08 Databases and Digital Resources\\01 Good Housekeeping\\Video Compression Comparison\\server_heic.csv')



#concatenate dataframes, reindex new video list
video_list = pd.concat([mp4_df,mov_df,heic_df], ignore_index=True)



#define parameters
bitrate = "5M"
vid_format = ".mp4"
frame_rate = "30"
codec = "h264"
temp_file = "C:\\Users\\brian.cruice\\Desktop\\test videos\\script test\\temp_vid" + vid_format

#read list of files from directory walk


for index,row in video_list.iterrows():
    #check metadata, evaluate if the video passes check
    vid_path = video_list.iloc[index]['path']
    new_vid_path = os.path.splitext(vid_path)[0] + "_compressed" + vid_format
    #if((eval(video_list['framerate'][index])) | (video_list['bitrate (kbps)'][index] > 5100)):
    if video_list['bitrate (kbps)'][index] > 5100:
        command_prompt = 'ffmpeg -y -i "' + vid_path + '" -b:v ' \
            + bitrate + ' "' + temp_file + '"'
        os.system(command_prompt)
        if os.path.isfile(new_vid_path) == True:
            os.remove(new_vid_path)
            os.rename(temp_file, new_vid_path)
            print 'file written over: ' + new_vid_path
        elif os.path.isfile(new_vid_path) == False:
            os.rename(temp_file, new_vid_path)
            print 'new file written: ' + new_vid_path
