public with sharing class VisionMetrixCircuitIterable implements Iterable<SObject>, Iterator<SObject>{
    private List<SObject> records;
    private Integer index = 0;
    public VisionMetrixCircuitIterable() {
        this.records = VisionMetrixCallOut.pullAllCircuits();
    }

    public Iterator<SObject> iterator() {
        return this;
    }

    public boolean hasNext() {
        return index < records.size();
    }

    public SObject next() {
        return records.get(index++);
    }
}