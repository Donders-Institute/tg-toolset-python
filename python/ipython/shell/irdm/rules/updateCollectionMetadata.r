updateCollectionMetadata {
    cmsConvertInput(*kv_str, *kv_str_ext);
    uiUpdateCollectionMetadata(*kv_str_ext, *out);
}
INPUT *kv_str=$"collName=/rdmtst/di/dccn/DAC_3010000.01%keyword_freetext=DICOM&&raw data&&MRI"
OUTPUT *out
