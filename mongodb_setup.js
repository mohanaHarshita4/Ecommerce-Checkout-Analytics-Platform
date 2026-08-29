// =====================================================
// MongoDB companion store
// Run with: mongosh mongodb_setup.js
// Purpose: hold unstructured / high volume data that does not
// fit cleanly into the relational schema, and give you a real
// SQL vs NoSQL comparison for the course's CAP theorem section.
// =====================================================

use("ecommerce_analytics_nosql");

// ---------------------------------------------------
// Collection 1: review text (linked back to Reviews.ReviewID in MySQL)
// ---------------------------------------------------
db.reviewText.insertMany([
  {
    reviewId: 1,          // matches Reviews.ReviewID in the relational DB
    productId: 1,
    customerId: 1,
    text: "Great sound quality and the case lasts all week on a single charge.",
    tags: ["sound quality", "battery life"],
    createdAt: new Date("2026-08-23")
  },
  {
    reviewId: 2,
    productId: 2,
    customerId: 2,
    text: "Noise cancelling works well on flights but they run a bit warm.",
    tags: ["noise cancelling", "comfort"],
    createdAt: new Date("2026-08-25")
  }
]);

// ---------------------------------------------------
// Collection 2: clickstream / browsing events (high write volume,
// schema varies by event type -- a natural fit for document storage)
// ---------------------------------------------------
db.clickstream.insertMany([
  { customerId: 1, sessionId: "s1001", eventType: "pageView", productId: 1, timestamp: new Date("2026-08-20T10:10:00Z") },
  { customerId: 1, sessionId: "s1001", eventType: "addToCart", productId: 1, timestamp: new Date("2026-08-20T10:12:00Z") },
  { customerId: 2, sessionId: "s1002", eventType: "pageView", productId: 2, timestamp: new Date("2026-08-22T14:20:00Z") },
  { customerId: 2, sessionId: "s1002", eventType: "search", query: "noise cancelling headphones", timestamp: new Date("2026-08-22T14:18:00Z") }
]);

// ---------------------------------------------------
// Example queries for your report / demo
// ---------------------------------------------------

// All review text for a given product
db.reviewText.find({ productId: 1 });

// Funnel style query: how many sessions added to cart after a page view
db.clickstream.aggregate([
  { $match: { eventType: { $in: ["pageView", "addToCart"] } } },
  { $group: { _id: { session: "$sessionId", type: "$eventType" }, count: { $sum: 1 } } }
]);

// Text search across review content
db.reviewText.createIndex({ text: "text" });
db.reviewText.find({ $text: { $search: "battery" } });
