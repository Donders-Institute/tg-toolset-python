c = get_config()

c.PromptManager.in_template = '[{_rdm_mystate}]\niRDM[\\#]: '
c.PromptManager.in2_template = '    .\\D.: '

## the banner should be printed before loading this profile
c.TerminalInteractiveShell.banner1 = """

 .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. |
| |     _____    | || |  _______     | || |  ________    | || | ____    ____ | |
| |    |_   _|   | || | |_   __ \    | || | |_   ___ `.  | || ||_   \  /   _|| |
| |      | |     | || |   | |__) |   | || |   | |   `. \ | || |  |   \/   |  | |
| |      | |     | || |   |  __ /    | || |   | |    | | | || |  | |\  /| |  | |
| |     _| |_    | || |  _| |  \ \_  | || |  _| |___.' / | || | _| |_\/_| |_ | |
| |    |_____|   | || | |____| |___| | || | |________.'  | || ||_____||_____|| |
| |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------' 

                  - an interactive shell for the DI-RDM system -

"""

c.TerminalInteractiveShell.banner2 = 'Tip: type "ihelp" to get start with iRDM'

c.TerminalIPythonApp.exec_files = [
    'preload.ipy'
]

#c.AliasManager.user_aliases = [
# ('icd' , 'icd'),
# ('ipwd' , 'ipwd')
#]

#---------------------------------------
#           RDM configuration
#---------------------------------------
# log level between 0-3 
c.RDM.log_level = 0

# type of iRODS client interface (icommand or restful) 
c.RDM.irods_iftype = 'restful'

# tabular display for list of collections: 
#   - tab_coll_header: header names of the table, the number following ':' specifies max. colume width
#   - tab_coll_dattrs: collection (irods) attributes mapped to each colume of the table
c.RDM.tab_coll_header = ['identifier', 'v:2', 'title:25', 'state', 'managers', 'contributors', 'viewers']
c.RDM.tab_coll_dattrs = ['collectionIdentifier', 'versionNumber', 'title', 'state', 'manager.displayName', 'contributor.displayName', 'viewer.displayName']
c.RDM.coll_displayed_dattrs = ['collectionIdentifier','identifierEPIC','identifierDOI','versionNumber','collName','title','descriptionAbstract','type','state','publisher','organisation','organisationalUnit','projectId','manager','contributor','viewer','creatorList','keyword_freetext','keyword_MeSH_2015','keyword_SFN_2013','associatedDAC','associatedRDC','associatedDSC','associatedPublication','ethicalApprovalIdentifier','creationDateTime','attributeLastUpdatedDateTime','embargoUntilDateTime','dataUseAgreement']

# tabular display for list of user profiles: 
#   - tab_user_header: header names of the table, the number following ':' specifies max. colume width
#   - tab_user_dattrs: user (irods) attributes mapped to each colume of the table
c.RDM.tab_user_header = ['display name', 'home organisation', 'OU user', 'OU admin', 'data access uid']
c.RDM.tab_user_dattrs = ['displayName', 'homeOrganisation', 'organisationalUnit', 'isAdminOf', 'irodsUserName']
c.RDM.user_displayed_dattrs = ['displayName','givenName','surName','email','homeOrganisation','organisationalUnit','isAdminOf','researcherId','openResearcherAndContributorId','personalWebsiteUrl']
