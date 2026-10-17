package features.transfers;

import io.karatelabs.junit6.Karate;
import org.junit.jupiter.api.DynamicNode;

class TransfersTest {

    @Karate.Test
    Iterable<DynamicNode> testTransfers() {
        return Karate.run().relativeTo(getClass());
    }
}
