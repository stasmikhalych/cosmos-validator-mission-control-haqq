package targets

import (
	"chainflow-vitwit/config"
	"encoding/json"
	"log"

	client "github.com/influxdata/influxdb1-client/v2"
)

func GetCurrentRewardsAmount(ops HTTPOptions, cfg *config.Config, c client.Client) {

	bp, err := createBatchPoints(cfg.InfluxDB.Database)
	if err != nil {
		log.Printf("Error: %v", err)
		return
	}

	resp, err := HitHTTPTarget(ops)
	if err != nil {
		log.Printf("Error: %v", err)
		return
	}

	var rewardsResp CurrentRewardsAmount
	err = json.Unmarshal(resp.Body, &rewardsResp)
	if err != nil {
		log.Printf("Error: %v", err)
		return
	}

	if len(rewardsResp.Result) > 0 {
		addressBalance := convertToCommaSeparated(rewardsResp.Result[0].Amount) + rewardsResp.Result[0].Denom
		_ = writeToInfluxDb(c, bp, "vcf_current_rewards_amount", map[string]string{}, map[string]interface{}{"amount": addressBalance})
		log.Printf("Address Balance: %s", addressBalance)
	}
}
