package com.automarket.storage;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetUrlRequest;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Addressing mode and endpoint resolution for the S3 client.
 *
 * <p>This is the configuration that decides whether uploads reach MinIO at all,
 * and none of it is checked at compile time or at startup — a wrong setting shows
 * up as the first upload failing with an unresolvable host. The SDK's
 * {@code utilities().getUrl()} resolves an object URL from the client's own
 * endpoint and addressing settings without a network call, so it verifies the
 * wiring offline.
 */
class S3ClientConfigTest {

    private static final GetUrlRequest OBJECT = GetUrlRequest.builder()
            .bucket("uploads").key("listings/photo.jpg").build();

    @Test
    void minioEndpointUsesPathStyleAddressing() {
        S3Client client = client("http://minio:9000", true, "minioadmin", "minioadmin");

        // Virtual-host style would be http://uploads.minio:9000/..., which does not
        // resolve in-cluster. The bucket must be in the path.
        assertThat(client.utilities().getUrl(OBJECT).toString())
                .isEqualTo("http://minio:9000/uploads/listings/photo.jpg");
    }

    @Test
    void blankEndpointStillTargetsAwsForTheConfiguredRegion() {
        // The pre-MinIO behaviour must survive: no endpoint, no static keys, and
        // the client resolves real AWS with virtual-host addressing.
        S3Client client = client("", false, "", "");

        assertThat(client.utilities().getUrl(OBJECT).toString())
                .isEqualTo("https://uploads.s3.eu-central-1.amazonaws.com/listings/photo.jpg");
    }

    private static S3Client client(String endpoint, boolean pathStyle, String accessKey, String secretKey) {
        S3ClientConfig config = new S3ClientConfig();
        ReflectionTestUtils.setField(config, "region", "eu-central-1");
        ReflectionTestUtils.setField(config, "endpoint", endpoint);
        ReflectionTestUtils.setField(config, "pathStyle", pathStyle);
        ReflectionTestUtils.setField(config, "accessKey", accessKey);
        ReflectionTestUtils.setField(config, "secretKey", secretKey);
        return config.s3Client();
    }
}
