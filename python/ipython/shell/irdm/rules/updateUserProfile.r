updateUserProfile {
    cmsConvertInput(*kv_str, *kv_str_ext);
    uiUpdateUserProfile(*kv_str_ext, *out);
}
INPUT *kv_str=$"irodsUserName=U505173-ru.nl%organisationalUnit=DCCN"
OUTPUT *out
