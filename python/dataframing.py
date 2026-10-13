import pandas as pd 

df = pd.read_csv('data/export.csv')
print(df.head())
# print(df.head())

# print(df.describe())
# print(df.isnull().sum())
# # print(df.info())    
# print(df['Mocodes'].head())
# print(df['Vict Descent'].head())
# print(df['Vict Descent'].unique()) # rename the codes to its actual form 
# print(df['Premis Cd'].unique())
# print(df['Premis Desc'].unique())
# print(df['Weapon Used Cd'].unique())
# print(df['Status'].unique())
# print(df['Crm Cd 1'].unique())
# print(df['Mocodes'].unique())
# print(df['Cross Street'].unique()
import os 
print(os.getcwd())