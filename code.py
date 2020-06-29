import pandas as  pd
import os


# Variable to change
location='d:\\test'     #instead of \ use \\
inputfile='LegitMetaSubmissionCoding.6.26.20-MASTER-moved-RG.xlsx'
################################


## reading the data
os.chdir(location)
d1=pd.read_excel(inputfile)

## to address same value in U and AI issue
ind1=d1['Variable name_PREDICTOR']==d1['Variable name_OUTCOME']
d2=d1.loc[ind1,:] # contained dropped records
d1.drop(ind1[ind1==True].index,inplace=True) # contain retained records


## to address repeating combinations issue
def sor(a):
    a=list(a)
    b=a[0:2]
    b.sort()
    b.append(str(a[2]))
    return "".join(b)
d1['Variable name_OUTCOME']=d1['Variable name_OUTCOME'].str.lower()
d1['Variable name_PREDICTOR']=d1['Variable name_PREDICTOR'].str.lower()
d1["new"]=d1[['Variable name_OUTCOME','Variable name_PREDICTOR','Article_number']].apply(lambda x: sor(x),axis=1 )
d1.sort_values(by='r',inplace=True,ascending=False) # this ensure that non null value of r is choosen while dropping
d3=d1.drop_duplicates(subset='new',keep = 'first') # contain retained records

li=[]
for i in d1.index: # loop to find out index of records which are dropped
    if i not in  d3.index:
        li.append(i)
  
## saving Droped records      
d2=pd.concat((d2,d1.loc[list(li),:]))
d2.sort_values(by='ID',inplace=True)
d2.drop('new',axis=1,inplace=True)
d2.to_excel('dropped.xlsx',index=False)


## saving retained records   
d3.sort_values(by='ID',inplace=True)
d3.drop('new',axis=1,inplace=True)
d3.to_excel('retained.xlsx',index=False)
