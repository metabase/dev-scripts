(ns bb.retry)

(defn retry
  "tries (thunk) until `retries` times or it returns a non-nil value"
  [retries thunk]
  (loop [count 0]
    (let [wait (int (dec (Math/pow 2 count)))]
      (Thread/sleep (* 1000 wait))
      (let [result (thunk)]
        (cond (some? result)
              result
              (< count retries)
              (do
                (println (format "Retry %d/%d returned nil, retrying in %d seconds..." count (inc retries) wait))
                (recur (inc count)))
              :else
              (println "No more retries left"))))))
