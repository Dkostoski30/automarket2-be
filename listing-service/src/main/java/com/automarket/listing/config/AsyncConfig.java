package com.automarket.listing.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Enables @Async, which was previously annotated but never switched on — there was no
 * @EnableAsync anywhere in the codebase, so AnalyticsService.recordView ran inline on
 * the request thread and silently recorded nothing.
 *
 * <p>A bounded pool rather than the Spring default: without an explicit executor,
 * @Async falls back to SimpleAsyncTaskExecutor, which creates a new thread per call
 * and has no upper limit. View recording happens on every listing page load, so an
 * unbounded executor turns a traffic spike into thread exhaustion.
 *
 * <p>CallerRunsPolicy is the deliberate saturation behaviour: if the queue fills, the
 * request thread records the view itself. That slows the caller instead of discarding
 * the measurement, and applies natural backpressure.
 */
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("listing-async-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(20);
        executor.initialize();
        return executor;
    }
}
